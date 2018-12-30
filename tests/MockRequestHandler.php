<?hh // strict

use type Nazg\Http\Server\RequestHandlerInterface;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Ytake\Hungrr\Response;
use type Ytake\Hungrr\StatusCode;
use namespace HH\Lib\Experimental\IO;
use function json_encode;

final class MockRequestHandler implements RequestHandlerInterface {

  public function handle(
    IO\WriteHandle $handle,
    ServerRequestInterface $_request
  ): ResponseInterface {
    $handle->rawWriteBlocking(json_encode([]));
    return new Response($handle, StatusCode::OK);
  }
}
