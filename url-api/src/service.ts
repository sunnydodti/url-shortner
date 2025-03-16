import { Context } from "hono";
import { getDbClient } from "./db";
import { TABLE_USER, TABLE_URL, TABLE_USER_URL } from "./db";

export async function getAllUsers(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_USER}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting users:", error);
        return c.text("Error getting users", 500);
    }
}

export async function getAllUrls(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_URL}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting urls:", error);
        return c.text("Error getting urls", 500);
    }
}

export async function getAllUserUrls(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_USER_URL}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting user_urls:", error);
        return c.text("Error getting user_urls", 500);
    }
}

export async function shortenUrl(c: Context) {
    try {
        const { url, shortCode } = await c.req.json();
        const original_url = url;
        let code = shortCode;
        const client = getDbClient(c);

        if (shortCode) {
            if (await isShortCodeTaken(c, shortCode)) {
                return c.text("url is already taken", 400);
            }
        }

        if (!shortCode) code = await getUniqueShortUrl(c);

        const result = await saveUrlToDbshortCode(c, original_url, code, "1");
        console.log(result);
        return c.json({ short_code: shortCode, original_url: original_url }, 201);
    } catch (error) {
        console.error("Error shortening URL:", error);
        return c.text("Error shortening URL", 500);
    }
}

export async function redirectUrl(c: Context) {
    try {
        const shortCode = c.req.param("shortCode");
        console.log('shortCode', shortCode);

        const client = getDbClient(c);
        const result = await client.query(`SELECT * FROM ${TABLE_URL} WHERE short_code = $1`, [
            shortCode,
        ]);
        if (result.rows.length === 0) {
            return c.text("Not Found", 404);
        }
        const originalUrl = result.rows[0].original_url;
        await client.query(`UPDATE ${TABLE_URL} SET clicks = clicks + 1 WHERE short_code = $1`, [
            shortCode,
        ]);
        return c.redirect(originalUrl, 301);
    } catch (error) {
        console.error("Error redirecting URL:", error);
        return c.text("Error redirecting URL", 500);
    }
}

export async function zara(c: Context) {
    try {
        const shortCode = c.req.param("shortCode");
        console.log('shortCode', shortCode);

        const client = getDbClient(c);
        const result = await client.query(`SELECT * FROM ${TABLE_URL} WHERE short_code = $1`, [
            shortCode,
        ]);
        if (result.rows.length === 0) {
            return c.text("Not Found", 404);
        }
        const originalUrl = result.rows[0].original_url;
        await client.query(`UPDATE ${TABLE_URL} SET clicks = clicks + 1 WHERE short_code = $1`, [
            shortCode,
        ]);
        return c.redirect(originalUrl, 302);
    } catch (error) {
        console.error("Error redirecting URL:", error);
        return c.text("Error redirecting URL", 500);
    }
}

export async function isUrlTaken(c: Context) {
    var isTaken: boolean = false;
    try {
        const url = c.req.param("url");
        if (!url) {
            isTaken = true;
            return c.json({ isTaken });
        }
        console.log("int try", url);
        console.log(url);

        console.log("in try b4", isTaken);
        isTaken = await isShortCodeTaken(c, url);
        console.log("in try aftr", isTaken);
        return c.json({ isTaken });
    } catch (error) {
        console.log("out try", error);
        return c.json({ isTaken });
    }
}

function generateShortUrl(): string {
    // Basic short code generator (you should use a more robust method in production)
    const characters = "ABCDEFGHJKMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789"; //  L, l & I removed
    let shortCode = "";
    for (let i = 0; i < 6; i++) {
        shortCode += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return shortCode;
}

async function saveUrlToDbshortCode(c: Context, url: string, shortCode: string, userId: string) {
    const client = getDbClient(c);
    var result;
    if (!userId) {
        let result = await client.query(
            `INSERT INTO ${TABLE_URL} (original_url, short_code) VALUES ($1, $2) RETURNING *`,
            [url, shortCode],
        );
        result = result.rows[0];
    }

    if (userId) {
        const result = await client.query(
            `INSERT INTO ${TABLE_USER_URL} (user_id, original_url, short_code) VALUES ($1, $2, $3) RETURNING *`,
            [userId, url, shortCode],
        );
        return result.rows[0];
    }

}

async function isShortCodeTaken(c: Context, shortCode: string) {
    const client = getDbClient(c);
    let isTaken = await client.query(
        `SELECT * FROM ${TABLE_URL} WHERE short_code = $1`,
        [shortCode],
    );
    console.log(shortCode);

    return isTaken.rows.length > 0;
}

async function getUniqueShortUrl(c: Context) {
    let shortCode = generateShortUrl();
    while (await isShortCodeTaken(c, shortCode)) {
        shortCode = generateShortUrl();
    }
    return shortCode;
}
