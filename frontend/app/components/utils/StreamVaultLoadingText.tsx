import { Center, Stack } from "@mantine/core";
import StreamVaultLoader from "./StreamVaultLoader";

interface params {
  message: string;
}

const StreamVaultLoadingText = ({ message }: params) => {
  return (
    <Center mt={10}>
      <Stack align="center">
        <StreamVaultLoader />
        <div>{message}</div>
      </Stack>
    </Center>
  );
}

export default StreamVaultLoadingText;
