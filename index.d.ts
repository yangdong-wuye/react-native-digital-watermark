interface IFile {
  uri: string;
  path: string;
}

declare module DigitalWatermark {
    function buildWatermark(uri: string, text: string): Promise<IFile>;
    function detectWatermark(uri: string): Promise<IFile>;
    function saveFile(uri: string): Promise<IFile>;
}

export default DigitalWatermark;
