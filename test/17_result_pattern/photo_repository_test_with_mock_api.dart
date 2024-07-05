import 'dart:async';
import 'dart:io';
import 'package:learn_dart_together/17_result_pattern/data/data_source/photo_api.dart';
import 'package:learn_dart_together/17_result_pattern/data/dto/photo_dto/photo_dto.dart';
import 'package:learn_dart_together/17_result_pattern/data/repository/photo_repository_impl.dart';
import 'package:learn_dart_together/17_result_pattern/core/result.dart';
import 'package:test/test.dart';

class MockPhotoApi implements PhotoApi {
  Exception? _exception;

  void setException(Exception exception) {
    _exception = exception;
  }

  @override
  Future<List<PhotoDto>> searchPhotos(
      {required String firstKeyword, String? secondKeyword}) async {
    if (_exception != null) {
      throw _exception!;
    }
    return [];
  }
}

void main() {
  late PhotoRepositoryImpl repository;
  late MockPhotoApi mockPhotoApi;

  setUp(() {
    mockPhotoApi = MockPhotoApi();
    repository = PhotoRepositoryImpl(photoApi: mockPhotoApi);
  });

  test('SocketException 처리', () async {
    mockPhotoApi.setException(SocketException('Failed to connect'));
    final result = await repository.getPhotos(firstKeyword: 'test');

    switch (result) {
      case Error(error: final errorMessage):
        expect(errorMessage, '네트워크 연결 에러가 발생했습니다');
      case Success(:final data):
        print(data);
    }
  });

  test('HttpException 처리', () async {
    mockPhotoApi.setException(HttpException('404 Not Found'));
    final result = await repository.getPhotos(firstKeyword: 'test');

    switch (result) {
      case Error(error: final errorMessage):
        expect(errorMessage, 'HTTP 연결 에러가 발생했습니다');
      case Success(:final data):
        print(data);
    }
  });

  test('TimeoutException 처리', () async {
    mockPhotoApi.setException(TimeoutException('Request timed out'));
    final result = await repository.getPhotos(firstKeyword: 'test');

    switch (result) {
      case Error(error: final errorMessage):
        expect(errorMessage, '요청 시간이 초과되었습니다');
      case Success(:final data):
        print(data);
    }
  });

  test('FormatException 처리', () async {
    mockPhotoApi.setException(FormatException('Invalid data format'));
    final result = await repository.getPhotos(firstKeyword: 'test');

    switch (result) {
      case Error(error: final errorMessage):
        expect(errorMessage, '데이터 형식 에러가 발생했습니다');
      case Success(:final data):
        print(data);
    }
  });

  test('기타 예외 처리', () async {
    mockPhotoApi.setException(Exception('Unknown error'));
    final result = await repository.getPhotos(firstKeyword: 'test');

    switch (result) {
      case Error(error: final errorMessage):
        expect(errorMessage.contains('알 수 없는 오류가 발생했습니다'), true);
      case Success(:final data):
        print(data);
    }
  });
}
