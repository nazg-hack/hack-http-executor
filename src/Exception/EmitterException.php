<?hh // strict

namespace Ytake\HackHttpExecutor\Exception;

use RuntimeException;

final class EmitterException extends RuntimeException {
  public static function forHeadersSent(): this {
    return new self('Unable to emit response; headers already sent');
  }

  public static function forOutputSent(): this {
    return new self('Output has been emitted previously; cannot emit response');
  }
}
