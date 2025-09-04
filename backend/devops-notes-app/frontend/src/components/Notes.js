import React, { useEffect, useState } from "react";
import { fetchNotes } from "../api";

function Notes() {
  const [notes, setNotes] = useState([]);

  useEffect(() => {
    fetchNotes().then(setNotes);
  }, []);

  return (
    <div>
      <h2>Notes</h2>
      <ul>
        {notes.map((note) => (
          <li key={note.id}>{note.title}: {note.content}</li>
        ))}
      </ul>
    </div>
  );
}

export default Notes;
