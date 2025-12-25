import { AxiosInstance } from "axios";
import { ApiResponse } from "./useAxios";
import { useQuery } from "@tanstack/react-query";
import { Video } from "./useVideos";

export interface StreamVaultInformation {
  commit_hash: string;
  tag: string;
  build_time: string;
  uptime: string;
  program_versions: StreamVaultProgramVersions;
}

export interface StreamVaultProgramVersions {
  ffmpeg: string;
  twitch_downloader: string;
  yt_dlp: string;
}

export interface StreamVaultVideoStatistics {
  video_count: number;
  channel_count: number;
  channel_videos: Record<string, number>;
  video_types: Record<string, number>;
}

export interface StreamVaultSystemOverview {
  videos_directory_free_space: number; // Free space in bytes
  videos_directory_used_space: number; // Used space in bytes
  cpu_cores: number; // Number of CPU cores
  memory_total: number; // Total memory in bytes
}

export interface StreamVaultStorageDistribution {
  storage_distribution: Record<string, number>; // Map of channel names to total storage used
  largest_videos: Video[]; // List of top largest videos
}

const getStreamVaultInformation = async (
  axiosPrivate: AxiosInstance
): Promise<StreamVaultInformation> => {
  const response = await axiosPrivate.get<ApiResponse<StreamVaultInformation>>(
    "/api/v1/admin/info"
  );
  return response.data.data;
};

const useGetStreamVaultInformation = (axiosPrivate: AxiosInstance) => {
  return useQuery({
    queryKey: ["streamvault-information"],
    queryFn: () => getStreamVaultInformation(axiosPrivate),
  });
};

const getStreamVaultVideoStatistics = async (
  axiosPrivate: AxiosInstance
): Promise<StreamVaultVideoStatistics> => {
  const response = await axiosPrivate.get<ApiResponse<StreamVaultVideoStatistics>>(
    "/api/v1/admin/video-statistics"
  );
  return response.data.data;
};

const useGetStreamVaultVideoStatistics = (axiosPrivate: AxiosInstance) => {
  return useQuery({
    queryKey: ["streamvault-video-statistics"],
    queryFn: () => getStreamVaultVideoStatistics(axiosPrivate),
  });
};

const getStreamVaultSystemOverview = async (
  axiosPrivate: AxiosInstance
): Promise<StreamVaultSystemOverview> => {
  const response = await axiosPrivate.get<ApiResponse<StreamVaultSystemOverview>>(
    "/api/v1/admin/system-overview"
  );
  return response.data.data;
};

const useGetStreamVaultSystemOverview = (axiosPrivate: AxiosInstance) => {
  return useQuery({
    queryKey: ["streamvault-system-overview"],
    queryFn: () => getStreamVaultSystemOverview(axiosPrivate),
  });
};

const getStreamVaultStorageDistribution = async (
  axiosPrivate: AxiosInstance
): Promise<StreamVaultStorageDistribution> => {
  const response = await axiosPrivate.get<
    ApiResponse<StreamVaultStorageDistribution>
  >("/api/v1/admin/storage-distribution");
  return response.data.data;
};

const useGetStreamVaultStorageDistribution = (axiosPrivate: AxiosInstance) => {
  return useQuery({
    queryKey: ["streamvault-storage-distribution"],
    queryFn: () => getStreamVaultStorageDistribution(axiosPrivate),
  });
};

export {
  useGetStreamVaultInformation,
  useGetStreamVaultVideoStatistics,
  useGetStreamVaultSystemOverview,
  useGetStreamVaultStorageDistribution,
};
