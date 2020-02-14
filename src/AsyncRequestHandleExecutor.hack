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
use type Nazg\Http\Server\AsyncRequestHandlerInterface;
use namespace HH\Lib\Experimental\IO;

class AsyncRequestHandleExecutor {

  public function __construct(
    private IO\ReadHandle $readHandle,
    private IO\CloseableWriteHandle $writeHandle,
    private AsyncRequestHandlerInterface $handler,
    private Emitter\EmitterInterface $emitter,
    private ServerRequestInterface $serverRequestFactory
  ) { }

  public async function runAsync(): Awaitable<void> {
    $response = await $this->handler->handleAsync(
      $this->writeHandle,
      $this->serverRequestFactory
    );
    await $this->emitter->emitAsync($this->readHandle, $response);
  }
}
