import React from "react";

function Register() {
  return (
    <div>
      <h2>Register</h2>
      <form>
        <input placeholder="Username" />
        <input placeholder="Password" type="password" />
        <button type="submit">Register</button>
      </form>
    </div>
  );
}

export default Register;
