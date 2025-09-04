import React from "react";

function Login() {
  return (
    <div>
      <h2>Login</h2>
      <form>
        <input placeholder="Username" />
        <input placeholder="Password" type="password" />
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default Login;
