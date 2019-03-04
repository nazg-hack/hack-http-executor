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

use type HH\Lib\Experimental\IO\ReadHandle;
use type Facebook\Experimental\Http\Message\ResponseInterface;

class SapiEmitter implements EmitterInterface {
  use SapiEmitterTrait;

  public function emit(
    ReadHandle $readHandle,
    ResponseInterface $response
  ): bool {
    $this->assertNoPreviousOutput();
    $this->emitHeaders($response);
    $this->emitStatusLine($response);
    $this->emitBody($readHandle);
    return true;
  }

  private function emitBody(
    ReadHandle $readHandle,
  ): void {
    echo $readHandle->rawReadBlocking();
  }
}
