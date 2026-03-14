$file = "web\WEB-INF\views\home.jsp"
$content = Get-Content $file -Raw -Encoding UTF8
$content = $content.Replace('fill="currentColor"', 'fill="#0f4c81"')
# Also add ?v=2 to style.css to bust cache
$content = $content.Replace('href="<%=request.getContextPath()%>/css/style.css"', 'href="<%=request.getContextPath()%>/css/style.css?v=2"')
Set-Content $file -Value $content -Encoding UTF8 -NoNewline
Write-Host "home.jsp updated."
