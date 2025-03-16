import { Hono } from "hono";
import { routes } from "./routes";
import { handleDbConnection } from "./db";

const app = new Hono<{ Bindings: Env }>();

// Middleware to handle database connection
app.use("*", handleDbConnection);

// Mount the routes
app.route("/", routes);

export default app;
