<?hh // strict

namespace Ytake\HackHttpExecutor\Emitter;

use type SplStack;
use type Facebook\Experimental\Http\Message\ResponseInterface;

class EmitterStack<T> extends SplStack<T> implements EmitterInterface {

  public function emit(ResponseInterface $response) : bool {
    foreach ($this as $emitter) {
      if($emitter is EmitterInterface) {
        if (false !== $emitter->emit($response)) {
          return true;
        }
      }
    }
    return false;
  }
}
