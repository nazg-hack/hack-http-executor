use type Ytake\Hungrr\ServerRequestFactory;
use type Nazg\HttpExecutor\AsyncRequestHandleExecutor;
use type Nazg\HttpExecutor\Emitter\EmitterStack;
use type Facebook\HackTest\HackTest;
use namespace HH\Lib\Experimental\IO;

use function Facebook\FBExpect\expect;
use function ob_start;
use function ob_end_clean;

final class AsyncRequestHandleExecutorTest extends HackTest {

  public async function testShouldReturnNullStackEmitter(): Awaitable<void> {
    $stack = new EmitterStack();
    $stack->push(new OverrideSapiEmitter());
    list($readHandle, $writeHandle) = IO\pipe_nd();
    $executor = new AsyncRequestHandleExecutor(
      $readHandle,
      $writeHandle,
      new MockAsyncRequestHandler(),
      $stack,
      ServerRequestFactory::fromGlobals()
    );
    ob_start();
    /* HH_FIXME[4119] ignore types for testing */
    $result = await $executor->runAsync();
    /* HH_FIXME[4119] ignore types for testing */
    expect($result)->toBeNull();
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('');
  }
}
