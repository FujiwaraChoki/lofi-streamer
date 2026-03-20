const { app, BrowserWindow } = require("electron");
const path = require("path");
const http = require("http");
const fs = require("fs");

const PARTITION = "persist:youtube";

function createWindow() {
  const html = fs.readFileSync(path.join(__dirname, "player.html"), "utf-8");

  // Serve over HTTP so YouTube gets a valid Referer
  const server = http.createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(html);
  });

  server.listen(0, "127.0.0.1", () => {
    const port = server.address().port;

    const win = new BrowserWindow({
      width: 520,
      height: 380,
      minWidth: 400,
      minHeight: 300,
      title: "Lofi Streamer",
      titleBarStyle: "default",
      backgroundColor: "#0f0f0f",
      webPreferences: {
        partition: PARTITION,
      },
    });

    win.setMenuBarVisibility(false);
    win.loadURL(`http://127.0.0.1:${port}`);

    win.webContents.setWindowOpenHandler(({ url }) => {
      require("electron").shell.openExternal(url);
      return { action: "deny" };
    });

    win.on("closed", () => server.close());
  });
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  app.quit();
});
