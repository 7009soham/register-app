<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DecimalFormat" %>

<%!
  private static String htmlEscape(String value) {
    if (value == null) return "";
    return value
      .replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }

  private static String formatDuration(long millis) {
    if (millis < 0) millis = 0;
    long seconds = millis / 1000;
    long days = seconds / 86400;
    seconds %= 86400;
    long hours = seconds / 3600;
    seconds %= 3600;
    long minutes = seconds / 60;
    seconds %= 60;
    return days + "d " + hours + "h " + minutes + "m " + seconds + "s";
  }
%>

<%
  // Persist a start time in application scope to approximate "app uptime".
  Long appStartTimeMillis = (Long) application.getAttribute("appStartTimeMillis");
  if (appStartTimeMillis == null) {
    appStartTimeMillis = System.currentTimeMillis();
    application.setAttribute("appStartTimeMillis", appStartTimeMillis);
  }

  Date serverTime = new Date();
  long uptimeMillis = System.currentTimeMillis() - appStartTimeMillis;

  Runtime rt = Runtime.getRuntime();
  long total = rt.totalMemory();
  long free = rt.freeMemory();
  long max = rt.maxMemory();

  DecimalFormat df = new DecimalFormat("0.00");
  double totalMb = total / (1024.0 * 1024.0);
  double freeMb = free / (1024.0 * 1024.0);
  double usedMb = (total - free) / (1024.0 * 1024.0);
  double maxMb = max / (1024.0 * 1024.0);

  Object gitCommitMessageObj = request.getAttribute("gitCommitMessage");
  if (gitCommitMessageObj == null) gitCommitMessageObj = session.getAttribute("gitCommitMessage");
  String gitCommitMessage = gitCommitMessageObj != null ? String.valueOf(gitCommitMessageObj) : null;
  if (gitCommitMessage == null || gitCommitMessage.trim().isEmpty()) {
    gitCommitMessage = System.getenv("GIT_COMMIT_MESSAGE");
  }
  if (gitCommitMessage == null || gitCommitMessage.trim().isEmpty()) {
    String gitCommit = System.getenv("GIT_COMMIT");
    gitCommitMessage = (gitCommit != null && !gitCommit.trim().isEmpty())
      ? ("Commit: " + gitCommit)
      : "Not available (set request/session attribute gitCommitMessage, or env var GIT_COMMIT_MESSAGE).";
  }

  Object buildNumberObj = request.getAttribute("buildNumber");
  if (buildNumberObj == null) buildNumberObj = session.getAttribute("buildNumber");
  String buildNumber = buildNumberObj != null ? String.valueOf(buildNumberObj) : null;
  if (buildNumber == null || buildNumber.trim().isEmpty()) {
    buildNumber = System.getenv("BUILD_NUMBER");
  }
  if (buildNumber == null || buildNumber.trim().isEmpty()) {
    buildNumber = "N/A";
  }

  // Placeholder value unless you wire a real Sonar API call.
  String sonarQualityGate = "UNKNOWN";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>DevOps Dashboard — Runtime Info</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; }
    h1 { margin: 0 0 8px 0; }
    .subtitle { margin: 0 0 20px 0; color: #444; }
    .nav a { margin-right: 12px; }
    table { border-collapse: collapse; width: 100%; max-width: 900px; }
    th, td { border: 1px solid #ddd; padding: 10px; text-align: left; vertical-align: top; }
    th { background: #f6f6f6; width: 280px; }
    .badge { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 12px; border: 1px solid #bbb; background: #f6f6f6; }
  </style>
</head>
<body>

  <div class="nav">
    <a href="index.jsp">Home</a>
    <a href="dashboard.jsp">DevOps Dashboard</a>
    <a href="#" aria-disabled="true">Login</a>
  </div>

  <h1>DevOps Dashboard — Runtime Info</h1>
  <p class="subtitle">A lightweight view of runtime and CI/CD metadata (no backend/config changes).</p>

  <table>
    <tr>
      <th>Current Server Time</th>
      <td><%= serverTime %></td>
    </tr>
    <tr>
      <th>Application Uptime</th>
      <td><%= formatDuration(uptimeMillis) %></td>
    </tr>
    <tr>
      <th>JVM Memory Usage</th>
      <td>
        Used: <%= df.format(usedMb) %> MB<br />
        Free: <%= df.format(freeMb) %> MB<br />
        Total: <%= df.format(totalMb) %> MB<br />
        Max: <%= df.format(maxMb) %> MB
      </td>
    </tr>
    <tr>
      <th>Last Git Commit Message</th>
      <td><%= htmlEscape(gitCommitMessage) %></td>
    </tr>
    <tr>
      <th>CI Build Number</th>
      <td><%= htmlEscape(buildNumber) %></td>
    </tr>
    <tr>
      <th>Sonar Quality Gate</th>
      <td>
        <span class="badge"><%= sonarQualityGate %></span>
        <span style="margin-left: 8px; color: #555;">(placeholder)</span>
      </td>
    </tr>
  </table>

</body>
</html>
