extension GalleryViewModel {
    convenience init() {
        self.init(
            loader: ImageDirectoryLoader(),
            deleter: FileImageDeleter()
        )
    }

    convenience init(loader: any ImageLoading) {
        self.init(loader: loader, deleter: FileImageDeleter())
    }
}
