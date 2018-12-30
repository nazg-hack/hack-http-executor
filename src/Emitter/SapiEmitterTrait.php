<?hh // strict

/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2018-2019 Yuuki Takezawa
 *
 */
namespace Nazg\HackHttpExecutor\Emitter;

use type Nazg\HackHttpExecutor\Emitter\EmitterInterface;
use type Nazg\HackHttpExecutor\Exception\EmitterException;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use namespace HH\Lib\Str;

use function ob_get_length;
use function ob_get_level;
use function header;
use function headers_sent;

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

  protected function putStatusLine(
    string $version,
    int $statusCode,
    string $reasonPhrase,
    bool $_replace,
  ): void {
    header(
      Str\format(
        'HTTP/%s %d%s',
        $version,
        $statusCode,
        ($reasonPhrase ? ' ' . $reasonPhrase : '')
      ),
      true,
      $statusCode
    );
  }

  private function emitStatusLine(ResponseInterface $response): void {
    $statusCode   = $response->getStatusCode();
    $this->putStatusLine(
      $response->getProtocolVersion(),
      $statusCode,
      $response->getReasonPhrase(),
      true,
    );
  }

  protected function putHeaders(
    string $name,
    string $value,
    bool $first,
    int $statusCode
  ): void {
    header(Str\format('%s: %s', $name, $value), $first, $statusCode);
  }

  private function emitHeaders(ResponseInterface $response): void {
    $statusCode = $response->getStatusCode();
    foreach ($response->getHeaders() as $header => $values) {
      $name = $this->filterHeader($header);
      $first = $name === 'Set-Cookie' ? false : true;
      foreach ($values as $value) {
        $this->putHeaders($name, $value, $first, $statusCode);
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
