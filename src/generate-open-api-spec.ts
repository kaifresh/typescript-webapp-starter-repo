import 'reflect-metadata'; // Must come before routing-controllers  @see https://github.com/typestack/routing-controllers#installation
import * as fs from 'fs';
const program = require('commander');

import {validationMetadatasToSchemas} from 'class-validator-jsonschema';
// @ts-ignore that defaultMetadataStorage isn't picked up as an exported member by the TS linter
import {defaultMetadataStorage} from 'class-transformer';
import {getMetadataArgsStorage} from 'routing-controllers';
import {routingControllersToSpec} from 'routing-controllers-openapi';
import {Controller, mapExpressServerOptionsForController} from "./controllers/controller";

/**
 * Create an object reflecting a swagger spec for `ControllerClass`
 * @param ControllerClass
 * @note it is expected that ControllerClass will be decorated appropriately with `routing-controllers` decorators to mark various information as being part of a swagger spec
 * @see https://github.com/epiphone/routing-controllers-openapi/blob/master/sample/01-basic/app.ts
 */
export function generateSpecForController(ControllerClass: any) {
    const schemas = validationMetadatasToSchemas({
        classTransformerMetadataStorage: defaultMetadataStorage,
        refPointerPrefix: '#/components/schemas/',
    });
    const serverOptions = mapExpressServerOptionsForController(ControllerClass);
    const storage = getMetadataArgsStorage()
    const spec = routingControllersToSpec(storage, serverOptions, {
        info: {
            description: 'App Description',
            title: 'App Title',
            version: '0.0.1',
        },
        components: {
            schemas,
        },
    })
    return {spec, storage};
}

/**
 * create a swagger file for the HandleEmailSendRequestController and write it to disk
 * @param outpath
 */
export function createSwaggerFile(outpath = `${__dirname}/open-api-spec.json`) {
    const {spec} = generateSpecForController(Controller);
    fs.writeFileSync(
        outpath,
        JSON.stringify(spec, null, 4)
    );
}


program
    .option('-o, --outDir <path>', 'directory to output spec to');

program.parse(process.argv);

const options = program.opts();

createSwaggerFile(options.outDir || undefined);
