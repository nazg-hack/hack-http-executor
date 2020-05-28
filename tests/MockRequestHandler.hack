use type Nazg\Http\Server\RequestHandlerInterface;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Ytake\Hungrr\{Response, StatusCode};
use namespace HH\Lib\IO;
use function json_encode;

final class MockRequestHandler implements RequestHandlerInterface {

  public function handle(
    IO\WriteHandle $handle,
    ServerRequestInterface $_request
  ): ResponseInterface {
    $handle->write(json_encode(dict[]));
    return new Response($handle, StatusCode::OK);
  }
}
