import 'reflect-metadata';
import {Body, createExpressServer, Get, JsonController, Post} from "routing-controllers";
import {OpenAPI} from "routing-controllers-openapi";
import {StatusCodes} from "http-status-codes";
import {Express} from "express";
import {IsString} from "class-validator";
import {JSONSchema} from "class-validator-jsonschema";

export class EchoPayload {
    @IsString()
    @JSONSchema({
        description: 'A message to echo'
    })
    message!: string;

}

@JsonController()
export class Controller {
    @OpenAPI({
        description: 'Respond that we\'re alive!',
        responses: {
            [StatusCodes.INTERNAL_SERVER_ERROR]: {
                "content": {
                    "application/json": {}
                },
                "description": 'If an internal server error occurrs',
            }
        }
    })
    @Get('/')
    async handleRootRequest(
        @Body() request: {},
    ) {
        console.log(request);
        return 'alive';
    }

    @Post('/echo')
    async handleEchoRequest(
        @Body() request: EchoPayload,
    ) {
        return `You asked me "${request.message}"`;
    }
}

export function mapExpressServerOptionsForController(ControllerClass: any) {
    return {controllers: [ControllerClass],};
}

// creates express app, registers all controller routes and returns you express app instance
const expressServerOptions = mapExpressServerOptionsForController(Controller) // we specify controllers we want to use
export const routingControllersApp = createExpressServer(expressServerOptions) as Express;