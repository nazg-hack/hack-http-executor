use type Nazg\Http\Server\AsyncRequestHandlerInterface;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Ytake\Hungrr\{Response, StatusCode};
use namespace HH\Lib\Experimental\IO;
use function json_encode;

final class MockAsyncRequestHandler implements AsyncRequestHandlerInterface {

  public async function handleAsync(
    IO\WriteHandle $handle,
    ServerRequestInterface $_request
  ): Awaitable<ResponseInterface> {
    await $handle->writeAsync(json_encode(dict[]));
    if($handle is IO\NonDisposableHandle) {
      await $handle->closeAsync();
    }
    return new Response($handle, StatusCode::OK);
  }
}
