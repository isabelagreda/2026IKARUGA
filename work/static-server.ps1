Add-Type -AssemblyName System.Web
$root = 'C:\Users\Usuario\Documents\Codex\2026-07-28\quiero-que-creemos-un-nueva-pagina\outputs'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://127.0.0.1:8787/')
$listener.Start()
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = [System.Web.HttpUtility]::UrlDecode($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($path)) { $path = 'index.html' }
    $full = [IO.Path]::GetFullPath([IO.Path]::Combine($root, $path))
    if (-not $full.StartsWith($root) -or -not [IO.File]::Exists($full)) {
      $ctx.Response.StatusCode = 404
      $bytes = [Text.Encoding]::UTF8.GetBytes('Not found')
    } else {
      $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
      $ctx.Response.ContentType = switch ($ext) { '.html' { 'text/html; charset=utf-8' } '.png' { 'image/png' } '.pdf' { 'application/pdf' } default { 'application/octet-stream' } }
      $bytes = [IO.File]::ReadAllBytes($full)
    }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
  } catch { break }
}
