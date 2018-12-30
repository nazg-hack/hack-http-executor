<?hh // strict

use type Ytake\Hungrr\ServerRequestFactory;
use type Nazg\HttpExecutor\RequestHandleExecutor;
use type Nazg\HttpExecutor\Emitter\SapiEmitter;
use type Nazg\HttpExecutor\Emitter\EmitterStack;
use type Facebook\HackTest\HackTest;
use namespace HH\Lib\Experimental\IO;

use function Facebook\FBExpect\expect;
use function ob_start;
use function ob_end_clean;

final class RequestHandleExecutorTest extends HackTest {

  public function testShouldReturnNullStackEmitter(): void {
    $stack = new EmitterStack();
    $stack->push(new OverrideSapiEmitter());
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $executor = new RequestHandleExecutor(
      $readHandle,
      $writeHandle,
      new MockRequestHandler(),
      $stack,
      ServerRequestFactory::fromGlobals()
    );
    ob_start();
    /* HH_FIXME[4119] ignore types for testing */
    expect($executor->run())->toBeNull();
    ob_end_clean();
  }

  public function testShouldReturnNullSapiEmitter(): void {
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $executor = new RequestHandleExecutor(
      $readHandle,
      $writeHandle,
      new MockRequestHandler(),
      new SapiEmitter(),
      ServerRequestFactory::fromGlobals()
    );
    ob_start();
    /* HH_FIXME[4119] ignore types for testing */
    expect($executor->run())->toBeNull();
    ob_end_clean();
  }
}
