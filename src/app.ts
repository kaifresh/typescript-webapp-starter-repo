import {routingControllersApp} from "./controllers/controller";

// Constants
const PORT = 8081;
const HOST = '0.0.0.0';

routingControllersApp.listen(PORT, HOST, ()=>console.log(`Running on ${HOST}:${PORT}`));