<?hh // strict

namespace Ytake\HackHttpExecutor\Emitter;

use type Ytake\HackHttpExecutor\Exception\EmitterException;
use type Facebook\Experimental\Http\Message\ResponseInterface;

use namespace HH\Lib\Str;

class SapiEmitter implements EmitterInterface {
  use SapiEmitterTrait;

  public function emit(ResponseInterface $response): bool {
    $this->assertNoPreviousOutput();
    $this->emitHeaders($response);
    $this->emitStatusLine($response);
    $this->emitBody($response);
    return true;
  }

  private function emitBody(ResponseInterface $response): void {
    echo $response->getBody();
  }
}
