const http = require("node:http");

const server = http.createServer((req, res) => {
    const url = new URL(req.url, "http://localhost:3000");



    if (req.method === "GET" && url.pathname === "/submit") {
        const username = url.searchParams.get("username");
        res.writeHead(200, {
            "Content-Type": "text/plain; charset=utf-8"
        });
        res.end(`the sent message is: ${username}`);
        return;
    }
});
server.listen(3000, () => {
    console.log("server is runnin");
});
