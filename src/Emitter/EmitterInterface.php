<?hh // strict

namespace Ytake\HackHttpExecutor\Emitter;

use type Facebook\Experimental\Http\Message\ResponseInterface;

interface EmitterInterface {

  public function emit(
    ResponseInterface $response
  ) : bool;
}
