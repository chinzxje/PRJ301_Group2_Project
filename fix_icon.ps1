$filePath = "web\WEB-INF\views\home.jsp"
$content = Get-Content $filePath -Raw -Encoding UTF8

$svg = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg>'

# Replace logged-in user avatar (letter-based)
$oldPart1 = '<span class="avatar-icon">'
$oldPart2 = "
                                                    <%=currentUser.getFullName().substring(0,1).toUpperCase()%>
                                                </span>"
$old2 = $oldPart1 + $oldPart2
$new2 = '<span class="avatar-icon">' + $svg + '</span>'
$content = $content.Replace($old2, $new2)

Set-Content $filePath -Value $content -Encoding UTF8 -NoNewline
Write-Host "Done."
(Get-Content $filePath -Encoding UTF8) | Select-String "avatar-icon"
