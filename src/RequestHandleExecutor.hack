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
namespace Nazg\HttpExecutor;

use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Nazg\Http\Server\RequestHandlerInterface;
use namespace HH\Lib\Experimental\IO;

class RequestHandleExecutor {

  public function __construct(
    private IO\ReadHandle $readHandle,
    private IO\WriteHandle $writeHandle,
    private RequestHandlerInterface $handler,
    private Emitter\EmitterInterface $emitter,
    private ServerRequestInterface $serverRequestFactory
  ) { }

  public function run(): void {
    $response = $this->handler->handle(
      $this->writeHandle,
      $this->serverRequestFactory
    );
    $this->emitter->emit($this->readHandle, $response);
  }
}
