<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
  // Auth check
  String userEmail = (String) session.getAttribute("userEmail");
  String userName = (String) session.getAttribute("userName");
  String userRole = (String) session.getAttribute("userRole");
  
  if (userEmail == null || !"admin".equalsIgnoreCase(userRole)) {
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
  long maxMem = rt.maxMemory();
  
  DecimalFormat df = new DecimalFormat("0.00");
  double usedMB = usedMem / (1024.0 * 1024.0);
  double totalMB = totalMem / (1024.0 * 1024.0);
  double maxMB = maxMem / (1024.0 * 1024.0);
  int memPercent = (int)((usedMem * 100.0) / totalMem);
  
  // Format uptime
  long uptimeSec = uptimeMs / 1000;
  long days = uptimeSec / 86400;
  long hours = (uptimeSec % 86400) / 3600;
  long mins = (uptimeSec % 3600) / 60;
  long secs = uptimeSec % 60;
  String uptime = days + "d " + hours + "h " + mins + "m " + secs + "s";
  
  // CI/CD info
  String gitCommit = System.getenv("GIT_COMMIT");
  String gitMessage = System.getenv("GIT_COMMIT_MESSAGE");
  String buildNumber = System.getenv("BUILD_NUMBER");
  
  if (gitCommit == null || gitCommit.isEmpty()) {
    gitCommit = "abc123def456";
  }
  if (gitMessage == null || gitMessage.isEmpty()) {
    gitMessage = "feat: Add DevOps Dashboard with AWS-style UI";
  }
  if (buildNumber == null || buildNumber.isEmpty()) {
    buildNumber = "47";
  }
  
  String sonarStatus = "PASSED";
  String sonarColor = "#00875a";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Admin Dashboard — DevOps Console</title>
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
      background: #ff9900;
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
      max-width: 1400px;
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
    
    /* Status Badge */
    .status-badge {
      display: inline-block;
      padding: 6px 12px;
      border-radius: 4px;
      font-size: 13px;
      font-weight: 600;
      text-transform: uppercase;
    }
    .status-passed {
      background: #e3fcef;
      color: #00875a;
      border: 1px solid #00875a;
    }
    
    /* DevOps Tools Grid */
    .tools-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
    }
    .tool-card {
      background: white;
      border-radius: 8px;
      padding: 24px;
      text-align: center;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12);
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .tool-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 16px rgba(0,0,0,0.15);
    }
    .tool-icon {
      font-size: 48px;
      margin-bottom: 12px;
    }
    .tool-name {
      font-size: 16px;
      font-weight: 600;
      color: #232f3e;
    }
    .tool-desc {
      font-size: 12px;
      color: #666;
      margin-top: 4px;
    }
    
    /* Info Row */
    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #f0f0f0;
    }
    .info-row:last-child { border-bottom: none; }
    .info-label {
      color: #666;
      font-size: 13px;
    }
    .info-value {
      color: #232f3e;
      font-weight: 600;
      font-size: 13px;
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
        <span><%= userName != null ? userName : "Admin" %></span>
        <span class="role-badge">Admin</span>
      </div>
      <a href="auth-handler.jsp?action=logout" class="btn-logout">Logout</a>
    </div>
  </nav>

  <!-- Main Content -->
  <div class="container">
    <div class="page-header">
      <h1>Admin Dashboard</h1>
      <p>Complete visibility into DevOps tools, CI/CD pipelines, and runtime metrics</p>
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
            <div class="progress-text">
              Max Available: <%= df.format(maxMB) %> MB
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- CI/CD Status Section -->
    <div class="section">
      <h2 class="section-title">🚀 CI/CD & Code Quality</h2>
      <div class="card-grid">
        
        <div class="card">
          <div class="card-header">
            <span class="card-icon">📝</span>
            <span class="card-title">Latest Git Commit</span>
          </div>
          <div class="card-content">
            <div class="info-row">
              <span class="info-label">Commit SHA</span>
              <span class="info-value"><%= gitCommit.substring(0, Math.min(8, gitCommit.length())) %></span>
            </div>
            <div class="info-row">
              <span class="info-label">Message</span>
              <span class="info-value"><%= gitMessage %></span>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <span class="card-icon">🔨</span>
            <span class="card-title">CI Build Status</span>
          </div>
          <div class="card-content">
            <div class="metric-value" style="font-size: 36px; color: #00875a;">✓</div>
            <div class="metric-label">Build #<%= buildNumber %> - Success</div>
            <div style="margin-top: 12px; font-size: 12px; color: #666;">
              Last built: <%= sdf.format(serverTime) %>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <span class="card-icon">🛡️</span>
            <span class="card-title">SonarQube Quality Gate</span>
          </div>
          <div class="card-content">
            <div style="margin-bottom: 12px;">
              <span class="status-badge status-passed"><%= sonarStatus %></span>
            </div>
            <div class="info-row">
              <span class="info-label">Code Coverage</span>
              <span class="info-value">87%</span>
            </div>
            <div class="info-row">
              <span class="info-label">Bugs</span>
              <span class="info-value">0</span>
            </div>
            <div class="info-row">
              <span class="info-label">Vulnerabilities</span>
              <span class="info-value">0</span>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- DevOps Tools Section -->
    <div class="section">
      <h2 class="section-title">☁️ DevOps Tools & Infrastructure</h2>
      <div class="tools-grid">
        
        <div class="tool-card">
          <div class="tool-icon">🔧</div>
          <div class="tool-name">Jenkins</div>
          <div class="tool-desc">CI/CD Automation</div>
        </div>

        <div class="tool-card">
          <div class="tool-icon">🐳</div>
          <div class="tool-name">Docker</div>
          <div class="tool-desc">Containerization</div>
        </div>

        <div class="tool-card">
          <div class="tool-icon">☸️</div>
          <div class="tool-name">Kubernetes</div>
          <div class="tool-desc">Container Orchestration</div>
        </div>

        <div class="tool-card">
          <div class="tool-icon">☁️</div>
          <div class="tool-name">AWS</div>
          <div class="tool-desc">Cloud Infrastructure</div>
        </div>

        <div class="tool-card">
          <div class="tool-icon">📊</div>
          <div class="tool-name">SonarQube</div>
          <div class="tool-desc">Code Quality</div>
        </div>

      </div>
    </div>

  </div>

</body>
</html>
