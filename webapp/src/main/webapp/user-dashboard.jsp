<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
  // Auth check
  String userEmail = (String) session.getAttribute("userEmail");
  String userName = (String) session.getAttribute("userName");
  String userRole = (String) session.getAttribute("userRole");
  
  if (userEmail == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  // Track app uptime
  Long appStartTime = (Long) application.getAttribute("appStartTime");
  if (appStartTime == null) {
    appStartTime = System.currentTimeMillis();
    application.setAttribute("appStartTime", appStartTime);
  }

  // Compute metrics
  Date serverTime = new Date();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss z");
  long uptimeMs = System.currentTimeMillis() - appStartTime;
  
  Runtime rt = Runtime.getRuntime();
  long totalMem = rt.totalMemory();
  long freeMem = rt.freeMemory();
  long usedMem = totalMem - freeMem;
  
  DecimalFormat df = new DecimalFormat("0.00");
  double usedMB = usedMem / (1024.0 * 1024.0);
  double totalMB = totalMem / (1024.0 * 1024.0);
  int memPercent = (int)((usedMem * 100.0) / totalMem);
  
  // Format uptime
  long uptimeSec = uptimeMs / 1000;
  long days = uptimeSec / 86400;
  long hours = (uptimeSec % 86400) / 3600;
  long mins = (uptimeSec % 3600) / 60;
  long secs = uptimeSec % 60;
  String uptime = days + "d " + hours + "h " + mins + "m " + secs + "s";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>User Dashboard — DevOps Console</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
      background: #f7f9fc;
      color: #232f3e;
    }
    
    /* Top Navigation */
    .navbar {
      background: #232f3e;
      color: white;
      padding: 0 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 56px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .navbar-brand {
      font-size: 18px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .navbar-user {
      display: flex;
      align-items: center;
      gap: 20px;
      font-size: 14px;
    }
    .user-info {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .role-badge {
      background: #16a34a;
      padding: 2px 8px;
      border-radius: 3px;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
    }
    .btn-logout {
      background: transparent;
      border: 1px solid #fff;
      color: white;
      padding: 6px 16px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 13px;
      text-decoration: none;
      transition: background 0.2s;
    }
    .btn-logout:hover { background: rgba(255,255,255,0.1); }
    
    /* Main Container */
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 24px;
    }
    
    .page-header {
      margin-bottom: 24px;
    }
    .page-header h1 {
      font-size: 28px;
      margin-bottom: 8px;
    }
    .page-header p {
      color: #666;
      font-size: 14px;
    }
    
    .info-banner {
      background: #e0f2fe;
      border-left: 4px solid #0284c7;
      padding: 16px;
      border-radius: 4px;
      margin-bottom: 24px;
      font-size: 14px;
      color: #0c4a6e;
    }
    
    /* Section Headers */
    .section {
      margin-bottom: 32px;
    }
    .section-title {
      font-size: 18px;
      font-weight: 600;
      margin-bottom: 16px;
      color: #232f3e;
    }
    
    /* Card Grid */
    .card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
    }
    
    /* Card Styles */
    .card {
      background: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12);
      transition: box-shadow 0.2s;
    }
    .card:hover {
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    .card-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #eee;
    }
    .card-icon {
      font-size: 28px;
    }
    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: #232f3e;
    }
    .card-content {
      color: #333;
    }
    .metric-value {
      font-size: 32px;
      font-weight: 700;
      color: #232f3e;
      margin-bottom: 8px;
    }
    .metric-label {
      font-size: 13px;
      color: #666;
    }
    
    /* Memory Progress Bar */
    .progress-bar {
      background: #e0e0e0;
      height: 12px;
      border-radius: 6px;
      overflow: hidden;
      margin: 12px 0;
    }
    .progress-fill {
      background: linear-gradient(90deg, #667eea, #764ba2);
      height: 100%;
      transition: width 0.3s;
    }
    .progress-text {
      font-size: 12px;
      color: #666;
      margin-top: 4px;
    }
  </style>
</head>
<body>

  <!-- Top Navigation -->
  <nav class="navbar">
    <div class="navbar-brand">
      <span>🚀</span>
      <span>DevOps Console</span>
    </div>
    <div class="navbar-user">
      <div class="user-info">
        <span><%= userName != null ? userName : "User" %></span>
        <span class="role-badge">User</span>
      </div>
      <a href="auth-handler.jsp?action=logout" class="btn-logout">Logout</a>
    </div>
  </nav>

  <!-- Main Content -->
  <div class="container">
    <div class="page-header">
      <h1>User Dashboard</h1>
      <p>View runtime metrics and application health</p>
    </div>

    <div class="info-banner">
      ℹ️ <strong>Limited Access:</strong> You have read-only access to runtime metrics. For full DevOps visibility, contact your administrator for an Admin role.
    </div>

    <!-- Runtime Metrics Section -->
    <div class="section">
      <h2 class="section-title">📊 Runtime Metrics</h2>
      <div class="card-grid">
        
        <div class="card">
          <div class="card-header">
            <span class="card-icon">🕐</span>
            <span class="card-title">Server Time</span>
          </div>
          <div class="card-content">
            <div class="metric-value" style="font-size: 20px;"><%= sdf.format(serverTime) %></div>
            <div class="metric-label">Current timestamp on server</div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <span class="card-icon">⏱️</span>
            <span class="card-title">Application Uptime</span>
          </div>
          <div class="card-content">
            <div class="metric-value" style="font-size: 24px;"><%= uptime %></div>
            <div class="metric-label">Time since application started</div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <span class="card-icon">💾</span>
            <span class="card-title">JVM Memory Usage</span>
          </div>
          <div class="card-content">
            <div class="metric-value" style="font-size: 24px;"><%= memPercent %>%</div>
            <div class="progress-bar">
              <div class="progress-fill" style="width: <%= memPercent %>%;"></div>
            </div>
            <div class="progress-text">
              Used: <%= df.format(usedMB) %> MB / Total: <%= df.format(totalMB) %> MB
            </div>
          </div>
        </div>

      </div>
    </div>

  </div>

</body>
</html>
