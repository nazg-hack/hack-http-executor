use type Ytake\Hungrr\Response;
use type Ytake\Hungrr\StatusCode;
use type Ytake\Hungrr\Response\TextResponse;
use type Nazg\HttpExecutor\Emitter\SapiEmitter;
use type Nazg\HttpExecutor\Emitter\EmitterStack;
use type Facebook\HackTest\HackTest;
use namespace HH\Lib\Experimental\IO;

use function Facebook\FBExpect\expect;
use function ob_start;
use function ob_end_clean;

final class SapiEmitterTest extends HackTest {

  public async function testShouldAsync(): Awaitable<void> {
    $sapi = new SapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    await $writeHandle->writeAsync('async content');
    await $writeHandle->closeAsync();
    ob_start();
    await $sapi->emitAsync($readHandle, new Response($writeHandle, StatusCode::OK));
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('async content');
  }
}
