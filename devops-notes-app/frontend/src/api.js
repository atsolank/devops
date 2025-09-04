const API_URL = process.env.REACT_APP_API_URL || "http://localhost:8000/api";

export async function fetchNotes() {
  const res = await fetch(\`\${API_URL}/notes\`);
  return res.json();
}
