use type Ytake\Hungrr\{Response, StatusCode};
use type Nazg\HttpExecutor\Emitter\SapiEmitter;
use type Facebook\HackTest\HackTest;
use namespace HH\Lib\IO;

use function Facebook\FBExpect\expect;
use function ob_start;
use function ob_end_clean;

final class SapiEmitterTest extends HackTest {

  public async function testShouldAsync(): Awaitable<void> {
    $sapi = new SapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe();
    await $writeHandle->writeAsync('async content');
    $writeHandle->close();
    ob_start();
    await $sapi->emitAsync($readHandle, new Response($writeHandle, StatusCode::OK));
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('async content');
  }
}
