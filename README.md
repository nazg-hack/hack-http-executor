# Nazg\HackHttpExecutor

[![Build Status](https://travis-ci.org/nazg-hack/hack-http-executor.svg?branch=master)](https://travis-ci.org/nazg-hack/hack-http-executor)

This library provides utilities for:

 - Emitting [Hack HTTP Request and Response Interfaces](https://github.com/hhvm/hack-http-request-response-interfaces) responses.
 - Running [Hack HTTP Server Request Handlers](https://github.com/nazg-hack/http-server-request-handler) server request handlers, which involves marshaling a Hack HTTP Request and Response Interfaces ServerRequestInterface, handling exceptions due to request creation, and emitting the response returned by the composed request handler.

Inspired by [zend-httphandlerrunner](https://github.com/zendframework/zend-httphandlerrunner)

## Require

HHVM 3.30.0 and above.

## Installation

```bash
hhvm $(which composer) require nazg-hack/hack-http-executor
```

## Usage

```hack
<?hh //strict

use type Ytake\Hungrr\ServerRequestFactory;
use type Nazg\HackHttpExecutor\RequestHandleExecutor;
use type Nazg\HackHttpExecutor\Emitter\SapiEmitter;
use namespace HH\Lib\Experimental\IO;

<<__EntryPoint>>
function main(): noreturn {
  list($readHandle, $writeHandle) = IO\pipe_non_disposable();
  $executor = new RequestHandleExecutor(
    $readHandle,
    $writeHandle,
    new ExampleRequestHandler(),
    new SapiEmitter(),
    ServerRequestFactory::fromGlobals()
  );
  $executor->run();
}
```
