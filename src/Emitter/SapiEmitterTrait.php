<?hh // strict

namespace Ytake\HackHttpExecutor\Emitter;

use type Ytake\HackHttpExecutor\Exception\EmitterException;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Ytake\HackHttpExecutor\Emitter\EmitterInterface;
use namespace HH\Lib\Str;

use function ob_get_length;
use function ob_get_level;
use function headers_sent;
use function header;

trait SapiEmitterTrait {
  require implements EmitterInterface;

  private function assertNoPreviousOutput(): void {
    if (headers_sent()) {
      throw EmitterException::forHeadersSent();
    }
    if (ob_get_level() > 0 && ob_get_length() > 0) {
      throw EmitterException::forOutputSent();
    }
  }

  private function emitStatusLine(ResponseInterface $response): void {
    $reasonPhrase = $response->getReasonPhrase();
    $statusCode   = $response->getStatusCode();
    header(
      Str\format(
        'HTTP/%s %d%s',
        $response->getProtocolVersion(),
        $statusCode,
        ($reasonPhrase ? ' ' . $reasonPhrase : '')
      ), 
      true, 
      $statusCode
    );
  }

  private function emitHeaders(ResponseInterface $response): void {
    $statusCode = $response->getStatusCode();
    foreach ($response->getHeaders() as $header => $values) {
      $name = $this->filterHeader($header);
      $first = $name === 'Set-Cookie' ? false : true;
      foreach ($values as $value) {
        header(
          Str\format(
            '%s: %s',
            $name,
            $value
          ),
          $first,
          $statusCode
        );
        $first = false;
      }
    }
  }

  private function filterHeader(string $header): string {
    return Str\replace($header,'-', ' ')
    |> Str\capitalize_words($$)
    |> Str\replace($$, ' ', '-');
  }
}
