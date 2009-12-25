function evilBrowser() {
  return (navigator.appName == "Microsoft Internet Explorer" || ! window.addEventListener);
}

function checkBrowser(message) {
  if (evilBrowser()) {
    alert(message);
  }
}
