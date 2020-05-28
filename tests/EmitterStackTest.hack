use type Ytake\Hungrr\{Response, StatusCode};
use type Ytake\Hungrr\Response\TextResponse;
use type Nazg\HttpExecutor\Emitter\{EmitterStack, SapiEmitter};
use type Facebook\HackTest\HackTest;
use namespace HH\Lib\IO;

use function Facebook\FBExpect\expect;
use function ob_start;
use function ob_end_clean;

final class EmitterStackTest extends HackTest {

  <<__LateInit>> private EmitterStack $stack;

  <<__Override>>
  public async function beforeEachTestAsync(): Awaitable<void> {
    $this->stack = new EmitterStack();
  }

  public function testShouldEmitTrue(): void {
    $sapiEmmiter = new SapiEmitter();
    $this->stack->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_nd();
    $writeHandle->write('testing');
    ob_start();
    $result = $this->stack->emit(
      $readHandle,
      new Response($writeHandle, StatusCode::OK)
    );
    ob_end_clean();
    expect($result)->toBeTrue();
  }

  public function testShouldReturnMessageBody(): void {
    $sapiEmmiter = new SapiEmitter();
    $this->stack->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_nd();
    $writeHandle->write('content');
    ob_start();
    $_ = $this->stack->emit(
      $readHandle,
      new Response($writeHandle, StatusCode::OK)
    );
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('content');
  }

  public function testEmitsResponseHeaders(): void {
    $sapiEmmiter = new OverrideSapiEmitter();
    $this->stack->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_nd();
    $writeHandle->write('content');
    $response = new TextResponse($writeHandle, StatusCode::OK);
    ob_start();
    $_ = $this->stack->emit(
      $readHandle,
      $response
    );
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('content');
    list($header, $_, $_) = $sapiEmmiter->getPutHeaders()[0];
    expect($header)->toContainSubstring('Content-Type: text/plain');
  }

  public async function testMultipleSetCookieHeadersAreNotReplaced(): Awaitable<void> {
    $sapiEmmiter = new OverrideSapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe_nd();
    await $writeHandle->writeAsync('');
    await $writeHandle->closeAsync();
    $sapiEmmiter->emit($readHandle, (new Response($writeHandle))
      ->withStatus(200)
      ->withAddedHeader('Set-Cookie', vec['foo=bar', 'bar=baz']));
    expect($sapiEmmiter->getPutHeaders())
    ->toBeSame(vec[
      tuple('Set-Cookie: foo=bar', false, StatusCode::OK),
      tuple('Set-Cookie: bar=baz', false, StatusCode::OK),
    ]);
  }

  public async function testDoesNotLetResponseCodeBeOverriddenByHack(): Awaitable<void> {
    $sapiEmmiter = new OverrideSapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe_nd();
    await $writeHandle->writeAsync('');
    await $writeHandle->closeAsync();
    $response = (new Response($writeHandle))
      ->withStatus(StatusCode::ACCEPTED)
      ->withAddedHeader('Location', vec['http://api.my-service.com/12345678'])
      ->withAddedHeader('Content-Type', vec['text/plain']);
    $sapiEmmiter->emit($readHandle, $response);
    expect($sapiEmmiter->getPutHeaders())
      ->toBeSame(vec[
        tuple('Location: http://api.my-service.com/12345678', true, 202),
        tuple('Content-Type: text/plain', true, 202),
      ]);
    expect($sapiEmmiter->getPutStatusLine())
      ->toBeSame(vec[
        tuple('HTTP/1.1 202 Accepted', true, 202)
      ]);
  }

  public async function testShouldEmitOutput(): Awaitable<void> {
    $sapiEmmiter = new SapiEmitter();
    $this->stack->push($sapiEmmiter);
    $this->stack->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_nd();
    await $writeHandle->writeAsync('content');
    await $writeHandle->closeAsync();
    ob_start();
    await $this->stack->emitAsync(
      $readHandle,
      new Response($writeHandle, StatusCode::OK)
    );
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('content');
  }
}
