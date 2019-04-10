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
namespace Nazg\HttpExecutor\Emitter;

use type SplStack;
use type HH\Lib\Experimental\IO\ReadHandle;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use namespace HH\Lib\Vec;

class EmitterStack extends SplStack<EmitterInterface> implements EmitterInterface {

  public function emit(
    ReadHandle $readHandle,
    ResponseInterface $response
  ): bool {
    foreach ($this as $emitter) {
      if (false !== $emitter->emit($readHandle, $response)) {
        return true;
      }
    }
    return false;
  }

  public async function emitAsync(
    ReadHandle $readHandle,
    ResponseInterface $response
  ): Awaitable<bool> {
    foreach ($this as $emitter) {
      if (false !== $emitter->emit($readHandle, $response)) {
        return true;
      }
    }
    return false;
  }
}
