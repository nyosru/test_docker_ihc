const express = require("express");
const { chromium } = require("playwright-core");

const app = express();
app.use(express.json({ limit: "1mb" }));

app.post("/html", async (req, res) => {
    const url = req.body.url;

    if (!url) {
        return res.status(400).json({ error: "no url" });
    }

    let browser;

    try {
        browser = await chromium.launch({
            executablePath: "/usr/bin/chromium",
            headless: true,
            args: ["--no-sandbox", "--disable-dev-shm-usage"]
        });

        const page = await browser.newPage({
            viewport: { width: 1280, height: 2000 }
        });

        await page.goto(url, {
            waitUntil: "domcontentloaded",
            timeout: 60000
        });

        // ждём js
        await page.waitForTimeout(3000);

        // скролл
        for (let i = 0; i < 3; i++) {
            await page.mouse.wheel(0, 2000);
            await page.waitForTimeout(1500);
        }

        const html = await page.content();

        await browser.close();

        res.json({
            success: true,
            html: html
        });

    } catch (e) {
        if (browser) await browser.close();
        res.status(500).json({ error: e.toString() });
    }
});

app.listen(3000, () => {
    console.log("Parser started :3000");
});
