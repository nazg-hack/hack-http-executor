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

final class EmitterStackTest extends HackTest {

  private ?EmitterStack $stack;

  <<__Override>>
  public async function beforeEachTestAsync(): Awaitable<void> {
    $this->stack = new EmitterStack();
  }

  public function testShouldEmitTrue(): void {
    $sapiEmmiter = new SapiEmitter();
    $this->stack?->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    ob_start();
    $result = $this->stack?->emit(
      $readHandle,
      new Response($writeHandle, StatusCode::OK)
    );
    ob_end_clean();
    expect($result)->toBeTrue();
  }

  public function testShouldReturnMessageBody(): void {
    $sapiEmmiter = new SapiEmitter();
    $this->stack?->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $writeHandle->rawWriteBlocking('content');
    ob_start();
    $result = $this->stack?->emit(
      $readHandle,
      new Response($writeHandle, StatusCode::OK)
    );
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('content');
  }

  public function testEmitsResponseHeaders(): void {
    $sapiEmmiter = new OverrideSapiEmitter();
    $this->stack?->push($sapiEmmiter);
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $writeHandle->rawWriteBlocking('content');
    $response = new TextResponse($writeHandle, StatusCode::OK);
    ob_start();
    $result = $this->stack?->emit(
      $readHandle,
      $response
    );
    $out = ob_get_contents();
    ob_end_clean();
    expect($out)->toBeSame('content');
    list($header, $_, $_) = $sapiEmmiter->getPutHeaders()[0];
    expect($header)->toContain('Content-Type: text/plain');
  }

  public function testMultipleSetCookieHeadersAreNotReplaced(): void {
    $sapiEmmiter = new OverrideSapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $sapiEmmiter->emit($readHandle, (new Response($writeHandle))
      ->withStatus(200)
      ->withAddedHeader('Set-Cookie', vec['foo=bar', 'bar=baz']));
    expect($sapiEmmiter->getPutHeaders())
    ->toBeSame(vec[
      tuple('Set-Cookie: foo=bar', false, StatusCode::OK),
      tuple('Set-Cookie: bar=baz', false, StatusCode::OK),
    ]);
  }

  public function testDoesNotLetResponseCodeBeOverriddenByHack(): void {
    $sapiEmmiter = new OverrideSapiEmitter();
    list($readHandle, $writeHandle) = IO\pipe_non_disposable();
    $response = (new Response($writeHandle))
      ->withStatus(StatusCode::ACCEPTED)
      ->withAddedHeader('Location', vec['http://api.my-service.com/12345678'])
      ->withAddedHeader('Content-Type', vec['text/plain']);
    $sapiEmmiter->emit($readHandle, $response);
    $expectedStack = vec[
      tuple('Location: http://api.my-service.com/12345678', true, 202),
      tuple('Content-Type: text/plain', true, 202),
    ];
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
}
