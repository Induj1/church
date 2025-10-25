const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const multer = require('multer')
const { createClient } = require('@supabase/supabase-js')
require('dotenv').config()

const app = express()
// tighten CORS for browser-based clients: allow any origin but expose common headers
const corsOptions = {
  origin: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'apikey', 'Origin', 'Accept'],
  credentials: true,
}
app.use(cors(corsOptions))
app.options('*', cors(corsOptions))
app.use(bodyParser.json())

// multer for parsing multipart file uploads into memory
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 100 * 1024 * 1024 } })

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in environment')
  process.exit(1)
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

app.post('/api/content-metadata', async (req, res) => {
  try {
    const payload = req.body
    console.log('Received metadata POST:', JSON.stringify(payload).slice(0,1000))
    // basic validation
    if (!payload || !payload.path || !payload.url) {
      return res.status(400).json({ error: 'Missing required fields: path and url' })
    }

    const insert = {
      title: payload.title || null,
      description: payload.description || null,
      url: payload.url,
      path: payload.path,
      mime_type: payload.mime_type || null,
      size: payload.size || null,
      tags: payload.tags || null
    }

    // Remove null keys to avoid attempting to insert columns that may not exist
    Object.keys(insert).forEach((k) => {
      if (insert[k] === null || insert[k] === undefined) delete insert[k]
    })

    const { data, error } = await supabase.from('content').insert([insert]).select()
    if (error) {
      console.error('Supabase insert error:', error)
      // If RLS blocks the insert the error message includes 'new row violates row-level security policy'
      if (error.message && error.message.toLowerCase().includes('row-level')) {
        return res.status(403).json({ error: 'RLS: server rejected insert. Check policies or use service role key.' })
      }
      return res.status(500).json({ error: error.message })
    }

    res.json({ data })
  } catch (err) {
    console.error('Server error:', err)
    res.status(500).json({ error: String(err) })
  }
})

// Upload file server-side and insert metadata in one step (recommended)
app.post('/api/upload-file', upload.fields([{ name: 'file', maxCount: 1 }, { name: 'thumbnail', maxCount: 1 }]), async (req, res) => {
  try {
    const f = req.files?.file?.[0]
    const thumb = req.files?.thumbnail?.[0]
    if (!f) return res.status(400).json({ error: 'Missing file' })

  // optional fields
  const { title, description, tags, type } = req.body || {}

    // sanitize filename similar to client
    const originalName = f.originalname || 'file'
    const lastDot = originalName.lastIndexOf('.')
    const nameBase = lastDot !== -1 ? originalName.slice(0, lastDot) : originalName
    const ext = lastDot !== -1 ? originalName.slice(lastDot) : ''
    const safeBase = nameBase.replace(/[^a-zA-Z0-9_-]/g, '_')
    const safeName = `${safeBase}${ext}`
    const filePath = `${Date.now()}_${safeName}`

    // upload main file buffer using service role key
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('content')
      .upload(filePath, f.buffer, { contentType: f.mimetype, upsert: false })

    if (uploadError) {
      console.error('Server upload error:', uploadError)
      return res.status(500).json({ error: uploadError.message || uploadError })
    }

  // get public URL (normalize to public path)
  const { data: publicData } = supabase.storage.from('content').getPublicUrl(filePath)
  let publicUrl = publicData?.publicUrl || ''
    if (publicUrl && publicUrl.indexOf('/object/public/') === -1 && publicUrl.indexOf('/storage/v1/object/') !== -1) {
      publicUrl = publicUrl.replace('/storage/v1/object/', '/storage/v1/object/public/')
    }

  // If a thumbnail was provided, upload it and get its public URL and storage path
  let thumbnailUrl = null
  let thumbnailPath = null
    if (thumb) {
      const thumbName = `${Date.now()}_thumb_${thumb.originalname.replace(/[^a-zA-Z0-9_.-]/g,'_')}`
      const { data: thumbData, error: thumbError } = await supabase.storage
        .from('content')
        .upload(thumbName, thumb.buffer, { contentType: thumb.mimetype, upsert: false })
      if (!thumbError) {
        const { data: thumbPublic } = supabase.storage.from('content').getPublicUrl(thumbName)
        // normalize public url: getPublicUrl may already include '/object/public/' so only replace when necessary
        let thumbPublicUrl = thumbPublic?.publicUrl || null
        if (thumbPublicUrl) {
          if (thumbPublicUrl.indexOf('/object/public/') !== -1) {
            thumbnailUrl = encodeURI(thumbPublicUrl)
          } else if (thumbPublicUrl.indexOf('/storage/v1/object/') !== -1) {
            thumbnailUrl = encodeURI(thumbPublicUrl.replace('/storage/v1/object/', '/storage/v1/object/public/'))
          } else {
            thumbnailUrl = encodeURI(thumbPublicUrl)
          }
        }
        thumbnailPath = thumbName
      } else {
        console.error('Thumbnail upload error:', thumbError)
      }
    }

    // insert metadata
    // Build insert object and include type/thumbnail_path up-front so values get persisted.
    const insert = {
      title: title || originalName,
      description: description || null,
      url: encodeURI(publicUrl),
      path: filePath,
      mime_type: f.mimetype || null,
      tags: tags ? (typeof tags === 'string' ? JSON.parse(tags) : tags) : null,
      // include optional fields — will be stripped out if null/undefined below
      type: type || null,
      thumbnail_path: thumbnailPath || null,
    }

    // Remove any keys where value is null/undefined so Supabase/PostgREST doesn't reject unknown columns
    Object.keys(insert).forEach((k) => {
      if (insert[k] === null || insert[k] === undefined) {
        delete insert[k]
      }
    })

    const { data, error } = await supabase.from('content').insert([insert]).select()
    if (error) {
      console.error('Supabase insert error (server):', error)
      return res.status(500).json({ error: error.message })
    }

    // respond with the inserted row and public URLs for convenience
    res.json({ data, path: filePath, publicUrl: insert.url, thumbnailUrl: thumbnailUrl })
  } catch (err) {
    console.error('upload-file error:', err)
    res.status(500).json({ error: String(err) })
  }
})

// Generate a signed URL for a given path (useful for private buckets)
app.post('/api/signed-url', async (req, res) => {
  try {
    const { path, expires = 60 } = req.body || {}
    if (!path) return res.status(400).json({ error: 'Missing path' })
    const { data, error } = await supabase.storage.from('content').createSignedUrl(path, expires)
    if (error) {
      console.error('createSignedUrl error:', error)
      return res.status(500).json({ error: error.message })
    }
    res.json({ signedUrl: data.signedUrl, expires })
  } catch (err) {
    console.error('signed-url error:', err)
    res.status(500).json({ error: String(err) })
  }
})

// Proxy endpoint to fetch content rows using the service-role key (local dev only).
app.get('/api/content', async (req, res) => {
  try {
    // allow optional query params for ordering/limit if desired
    const { data, error } = await supabase.from('content').select('*').order('created_at', { ascending: false })
    if (error) {
      console.error('Supabase select error (server):', error)
      return res.status(500).json({ error: error.message })
    }

    // Attach thumbnail_url for rows that have a thumbnail_path so clients don't need
    // to build the storage public URL themselves.
    const enhanced = (data || []).map((row) => {
      const out = { ...row }
      try {
        if (row.thumbnail_path) {
          const { data: thumbPublic } = supabase.storage.from('content').getPublicUrl(row.thumbnail_path)
          let thumbPublicUrl = thumbPublic?.publicUrl || null
          if (thumbPublicUrl) {
            if (thumbPublicUrl.indexOf('/object/public/') !== -1) {
              out.thumbnail_url = encodeURI(thumbPublicUrl)
            } else if (thumbPublicUrl.indexOf('/storage/v1/object/') !== -1) {
              out.thumbnail_url = encodeURI(thumbPublicUrl.replace('/storage/v1/object/', '/storage/v1/object/public/'))
            } else {
              out.thumbnail_url = encodeURI(thumbPublicUrl)
            }
          }
        }
        // Ensure url is present and normalized for file public access
        if (row.path && !row.url) {
          const { data: publicData } = supabase.storage.from('content').getPublicUrl(row.path)
          let publicUrl = publicData?.publicUrl || null
          if (publicUrl && publicUrl.indexOf('/storage/v1/object/') !== -1 && publicUrl.indexOf('/object/public/') === -1) {
            publicUrl = publicUrl.replace('/storage/v1/object/', '/storage/v1/object/public/')
          }
          out.url = publicUrl ? encodeURI(publicUrl) : out.url
        }
      } catch (err) {
        // Non-fatal: if storage lookup fails just return the row as-is
        console.error('Error while enriching content row with thumbnail/public url:', err)
      }
      return out
    })

    res.json(enhanced)
  } catch (err) {
    console.error('proxy /api/content error:', err)
    res.status(500).json({ error: String(err) })
  }
})

// Health check endpoint for load balancers and platforms (Render) to probe
app.get('/healthz', (req, res) => {
  // lightweight check: ensure process is up. Do NOT expose sensitive details.
  res.status(200).json({ status: 'ok' })
})

const port = process.env.PORT || 3000
app.listen(port, () => console.log(`Admin proxy server listening on http://localhost:${port}`))
