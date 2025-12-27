<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.concurrent.ConcurrentHashMap" %>

<%!
  // In-memory user storage (demo only — survives for application lifetime)
  private static Map<String, String> users = new ConcurrentHashMap<>();
  private static Map<String, String> userNames = new ConcurrentHashMap<>();
  private static Map<String, String> userRoles = new ConcurrentHashMap<>();
  
  static {
    // Pre-populate demo accounts
    users.put("admin@example.com", "admin123");
    userNames.put("admin@example.com", "Admin User");
    userRoles.put("admin@example.com", "admin");
    
    users.put("user@example.com", "user123");
    userNames.put("user@example.com", "Demo User");
    userRoles.put("user@example.com", "user");
  }
%>

<%
  String action = request.getParameter("action");

  if ("register".equals(action)) {
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String role = request.getParameter("role");
    
    if (users.containsKey(email)) {
      response.sendRedirect("register.jsp?error=duplicate");
      return;
    }
    
    // Store new user
    users.put(email, password);
    userNames.put(email, name);
    userRoles.put(email, role != null ? role : "user");
    
    response.sendRedirect("login.jsp?registered=true");
    return;
  }

  if ("login".equals(action)) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    String storedPassword = users.get(email);
    if (storedPassword == null || !storedPassword.equals(password)) {
      response.sendRedirect("login.jsp?error=invalid");
      return;
    }
    
    // Set session attributes
    session.setAttribute("userEmail", email);
    session.setAttribute("userName", userNames.get(email));
    session.setAttribute("userRole", userRoles.get(email));
    session.setMaxInactiveInterval(30 * 60); // 30 minutes
    
    String role = userRoles.get(email);
    if ("admin".equalsIgnoreCase(role)) {
      response.sendRedirect("admin-dashboard.jsp");
    } else {
      response.sendRedirect("user-dashboard.jsp");
    }
    return;
  }

  if ("logout".equals(action)) {
    session.invalidate();
    response.sendRedirect("login.jsp");
    return;
  }

  response.sendRedirect("login.jsp");
%>
