function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }

    console.log("Old uri " + uri);
    console.log("New uri " + request.uri);

    return request;
}