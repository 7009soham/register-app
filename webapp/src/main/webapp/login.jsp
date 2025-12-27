<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Redirect if already logged in
  String sessionEmail = (String) session.getAttribute("userEmail");
  if (sessionEmail != null) {
    String userRole = (String) session.getAttribute("userRole");
    if ("admin".equalsIgnoreCase(userRole)) {
      response.sendRedirect("admin-dashboard.jsp");
    } else {
      response.sendRedirect("user-dashboard.jsp");
    }
    return;
  }
  String error = request.getParameter("error");
  String registered = request.getParameter("registered");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Login — DevOps Dashboard</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .login-box {
      background: white;
      border-radius: 8px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
      width: 100%;
      max-width: 420px;
      padding: 40px;
    }
    .header { text-align: center; margin-bottom: 30px; }
    .header h1 { color: #232f3e; font-size: 26px; margin-bottom: 8px; }
    .header p { color: #666; font-size: 13px; }
    .alert {
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 20px;
      font-size: 13px;
    }
    .alert-error {
      background: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
    }
    .alert-success {
      background: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
    }
    .form-group { margin-bottom: 20px; }
    label {
      display: block;
      color: #333;
      font-weight: 600;
      margin-bottom: 6px;
      font-size: 14px;
    }
    input[type="email"],
    input[type="password"] {
      width: 100%;
      padding: 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }
    input:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102,126,234,0.1);
    }
    .btn {
      width: 100%;
      padding: 12px;
      background: #667eea;
      color: white;
      border: none;
      border-radius: 4px;
      font-weight: 600;
      cursor: pointer;
      font-size: 14px;
      transition: background 0.2s;
    }
    .btn:hover { background: #5568d3; }
    .footer {
      text-align: center;
      margin-top: 20px;
      color: #666;
      font-size: 14px;
    }
    .footer a {
      color: #667eea;
      text-decoration: none;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <div class="login-box">
    <div class="header">
      <h1>🚀 DevOps Dashboard</h1>
      <p>Enterprise CI/CD & Runtime Metrics</p>
    </div>
    
    <% if ("invalid".equals(error)) { %>
      <div class="alert alert-error">❌ Invalid credentials. Try again.</div>
    <% } %>
    <% if ("registered".equals(registered)) { %>
      <div class="alert alert-success">✅ Registration successful! Please log in.</div>
    <% } %>
    
    <form method="POST" action="auth-handler.jsp">
      <input type="hidden" name="action" value="login">
      <div class="form-group">
        <label>Email Address</label>
        <input type="email" name="email" required placeholder="user@example.com">
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" required placeholder="Enter password">
      </div>
      <button type="submit" class="btn">Sign In</button>
    </form>
    
    <div class="footer">
      Don't have an account? <a href="register.jsp">Create one</a>
    </div>
  </div>
</body>
</html>
