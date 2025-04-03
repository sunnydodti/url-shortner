import { Hono } from "hono";
import { routes } from "./routes";
import { handleDbConnection } from "./db";
import { cors } from 'hono/cors'

const app = new Hono<{ Bindings: Env }>();

// Middleware to handle database connection
app.use("*", handleDbConnection);
app.use(cors());
// Mount the routes
app.route("/", routes);

export default app;
