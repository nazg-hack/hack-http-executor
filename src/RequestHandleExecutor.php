<?hh // strict

namespace Ytake\HackHttpExecutor;

use type Throwable;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Ytake\HackHttpServer\RequestHandlerInterface;

class RequestHandleExecutor {

  public function __construct(
    private RequestHandlerInterface $handler,
    private Emitter\EmitterInterface $emitter,
    private ServerRequestInterface $serverRequestFactory
  ) { }

  public function run(): void {
    $response = $this->handler->handle($this->serverRequestFactory);
    $this->emitter->emit($response);
  }
}
