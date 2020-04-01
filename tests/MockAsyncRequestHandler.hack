use type Nazg\Http\Server\AsyncRequestHandlerInterface;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Ytake\Hungrr\{Response, StatusCode};
use namespace HH\Lib\IO;
use function json_encode;

final class MockAsyncRequestHandler implements AsyncRequestHandlerInterface {

  public async function handleAsync(
    IO\WriteHandle $handle,
    ServerRequestInterface $_request
  ): Awaitable<ResponseInterface> {
    if($handle is IO\CloseableHandle) {
      await $handle->closeAsync();
    }
    return new Response($handle, StatusCode::OK);
  }
}
