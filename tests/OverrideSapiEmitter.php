<?hh // strict

use type Nazg\HttpExecutor\Emitter\SapiEmitter;

use namespace HH\Lib\Str;

final class OverrideSapiEmitter extends SapiEmitter {

  private vec<(string, bool, int)> $statusLine = vec[];
  private vec<(string, bool, int)> $headers = vec[];

  <<__Override>>
  protected function putStatusLine(
    string $version,
    int $statusCode,
    string $reasonPhrase,
    bool $replace,
  ): void {
    $this->statusLine[] = tuple(
      Str\format(
        'HTTP/%s %d%s',
        $version,
        $statusCode,
        ($reasonPhrase ? ' ' . $reasonPhrase : '')
      ),
      $replace,
      $statusCode,
    );
  }

  <<__Override>>
  protected function putHeaders(
    string $name,
    string $value,
    bool $first,
    int $statusCode
  ): void {
    $this->headers[] = tuple(
      Str\format('%s: %s', $name, $value),
      $first,
      $statusCode,
    );
  }

  public function getPutHeaders(): vec<(string, bool, int)> {
    return $this->headers;
  }

  public function getPutStatusLine(): vec<(string, bool, int)> {
    return $this->statusLine;
  }
}
