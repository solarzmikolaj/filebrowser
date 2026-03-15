declare module "mammoth/mammoth.browser" {
  export interface MammothResult {
    value: string;
    messages: Array<{
      type: string;
      message: string;
      error?: Error;
    }>;
  }

  export function convertToHtml(input: {
    arrayBuffer: ArrayBuffer;
  }): Promise<MammothResult>;

  const mammoth: {
    convertToHtml: typeof convertToHtml;
  };

  export default mammoth;
}
