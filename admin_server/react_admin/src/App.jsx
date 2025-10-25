import React, { useEffect, useState } from 'react'

export default function App() {
  const [file, setFile] = useState(null)
  const [thumbnail, setThumbnail] = useState(null)
  const [thumbnailPreview, setThumbnailPreview] = useState(null)
  const [contentType, setContentType] = useState('devotion')
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [tags, setTags] = useState('')
  const [status, setStatus] = useState('')
  const [uploaded, setUploaded] = useState(null)

  useEffect(() => {
    if (!thumbnail) {
      setThumbnailPreview(null)
      return
    }
    // Use FileReader to create a data URL preview (avoids blob: URLs which may be blocked
    // by strict Content-Security-Policy 'img-src' rules in dev servers).
    const fr = new FileReader()
    fr.onload = (ev) => {
      setThumbnailPreview(ev.target?.result ?? null)
    }
    fr.onerror = () => setThumbnailPreview(null)
    fr.readAsDataURL(thumbnail)
    return () => {
      // nothing to revoke for data URLs
    }
  }, [thumbnail])

  const onSubmit = async (e) => {
    e.preventDefault()
    if (!file) {
      setStatus('Please select a file to upload')
      return
    }

    setStatus('Uploading file to server...')

    const fd = new FormData()
    fd.append('file', file, file.name)
    fd.append('title', title)
    fd.append('description', description)
    fd.append('type', contentType || 'generic')
    fd.append('tags', JSON.stringify(tags ? tags.split(',').map(t => t.trim()) : []))
    if (thumbnail) {
      fd.append('thumbnail', thumbnail, thumbnail.name)
    }

    try {
      const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3000'
      const resp = await fetch(`${API_BASE}/api/upload-file`, {
        method: 'POST',
        body: fd
      })
      const body = await resp.json().catch(() => null)
      console.log('Server upload response', resp.status, body)
      if (!resp.ok) {
        const errMsg = body?.error || resp.statusText || String(body)
        setStatus('Upload error: ' + errMsg)
        return
      }

      setUploaded(body?.data?.[0] || body)
      setStatus('Upload complete')
      setFile(null)
      setThumbnail(null)
      setTitle('')
      setDescription('')
      setTags('')
    } catch (err) {
      console.error('Upload error', err)
      setStatus('Upload error: ' + String(err))
    }
  }

  return (
    <div className="app">
      <h1>Admin — Upload Content to Supabase</h1>
      <form onSubmit={onSubmit} className="form">
        <label>
          File
          <input type="file" onChange={(e) => setFile(e.target.files?.[0] ?? null)} />
        </label>

        <label>
          Thumbnail (optional)
          <input type="file" accept="image/*" onChange={(e) => setThumbnail(e.target.files?.[0] ?? null)} />
        </label>

        {thumbnailPreview && (
          <div style={{ marginBottom: 12 }}>
            <strong>Thumbnail preview:</strong>
            <div style={{ marginTop: 8 }}>
              <img src={thumbnailPreview} alt="thumbnail" style={{ maxWidth: 240, maxHeight: 160, borderRadius: 6 }} />
            </div>
          </div>
        )}

        <label>
          Section
          <select value={contentType} onChange={(e) => setContentType(e.target.value)}>
            <option value="devotion">Daily Devotion</option>
            <option value="sermon">Sermon Highlights</option>
            <option value="event">Upcoming Events</option>
            <option value="music">APC Music</option>
            <option value="book">APC Book</option>
            <option value="notes">Notes</option>
            <option value="bible">Bible</option>
            <option value="location">Location</option>
            <option value="other">Other</option>
          </select>
        </label>

        <label>
          Title
          <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Optional title" />
        </label>

        <label>
          Description
          <textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Optional description" />
        </label>

        <label>
          Tags (comma separated)
          <input value={tags} onChange={(e) => setTags(e.target.value)} placeholder="tag1, tag2" />
        </label>

        <div className="actions">
          <button type="submit">Upload</button>
        </div>
      </form>

      <div className="status">{status}</div>

      {uploaded && (
        <div className="uploaded">
          <h3>Uploaded</h3>
          <pre style={{ whiteSpace: 'pre-wrap' }}>{JSON.stringify(uploaded, null, 2)}</pre>
          {uploaded.url && (
            <p>
              <a href={uploaded.url} target="_blank" rel="noreferrer">Open file</a>
            </p>
          )}
        </div>
      )}

      <div className="notes">
        <h4>Notes</h4>
        <ul>
          <li>This app uploads the file to the server proxy which uses a Supabase service role key to store the file and insert metadata.</li>
          <li>Keep `admin_server/.env` with the service key secure and do not commit it.</li>
        </ul>
      </div>
    </div>
  )
}
