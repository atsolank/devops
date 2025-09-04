import React from "react";
import Notes from "./components/Notes";
import Login from "./components/Login";
import Register from "./components/Register";

function App() {
  return (
    <div>
      <h1>Notes App</h1>
      <Register />
      <Login />
      <Notes />
    </div>
  );
}

export default App;
